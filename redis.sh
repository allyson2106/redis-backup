# Define o diretório de log
log_dir="/var/log/redis-backup"

# Cria o diretório de log se ele não existir
mkdir -p "$log_dir"

# Define o arquivo de log padrão
log_file="$log_dir/redis-backup.log"

# Define o arquivo de erro
error_file="$log_dir/redis-backup.err"

# Imprime a hora de início no log
echo "$(date +"%Y-%m-%d %H:%M:%S") - Iniciando o backup do Elasticache" >> "$log_file"
# Define o nome do bucket S3 onde deseja copiar os backups de Elasticache
s3_bucket_name=${S3_BUCKET_NAME}

# Define a lista de regiões AWS onde deseja verificar os backups
aws_regions=${REGION}

for region in "${aws_regions[@]}"; do
  # Define a região da AWS onde o Elasticache está sendo executado
  aws configure set default.region $region

  # Obtém a lista de ReplicationGroups do Elasticache na região
  rep_groups=$(aws elasticache describe-replication-groups --query 'ReplicationGroups[*].{ID:ReplicationGroupId, Status:Status, Backup:SnapshotRetentionLimit}' | jq -r '.[] | select(.Status=="available") | .ID')
  for rep_group in $rep_groups; do
    # Obtém o nome do último backup automático do ReplicationGroup
    last_backup=$(aws elasticache describe-snapshots --replication-group-id $rep_group --query 'Snapshots[].SnapshotName' | jq -r 'last')

    if [ -n "$last_backup" ]; then
      # Define o caminho no S3 onde será armazenado o backup
      s3_path="$rep_group"

        # Copia o último backup para o bucket do S3 especificado
        if aws elasticache copy-snapshot --region $region --source-snapshot-name $last_backup --target-snapshot-name $s3_path/$last_backup --target-bucket $s3_bucket_name; then
          echo "O backup $last_backup foi copiado com sucesso para o bucket $s3_bucket_name/$s3_path."
        else
          echo "Erro ao copiar o backup $last_backup para o bucket $s3_bucket_name/$s3_path."
        fi
    else
      echo "Nenhum backup automático encontrado para o ReplicationGroup $rep_group na região $region."
    fi
  done 

  # Obtém a lista de clusters do Elasticache na região
  clusters=$(aws elasticache describe-cache-clusters --show-cache-node-info --query 'CacheClusters[*].{ID:CacheClusterId, Status:CacheClusterStatus, Backup:CacheClusterCreateTime}' | jq -r '.[] | select(.Status=="available") | .ID')  
  for cluster in $clusters; do
    # Obtém o nome do último backup automático do cluster
    last_backup=$(aws elasticache describe-snapshots --cache-cluster-id "$cluster" --query 'Snapshots[].SnapshotName' | jq -r 'last')

    if [ -n "$last_backup" ]; then
      # Define o caminho no S3 onde será armazenado o backup
      s3_path="clusters"
        # Copia o último backup para o bucket do S3 especificado
        if aws elasticache copy-snapshot --region "$region" --source-snapshot-name "$last_backup" --target-snapshot-name "$s3_path/$last_backup" --target-bucket "$s3_bucket_name"; then
          echo "$(date +"%Y-%m-%d %H:%M:%S") - O backup $last_backup foi copiado com sucesso para o bucket $s3_bucket_name/$s3_path." >> "$log_file"
        else
          echo "$(date +"%Y-%m-%d %H:%M:%S") - Erro ao copiar o backup $last_backup para o bucket $s3_bucket_name/$s3_path." >> "$error_file"
        fi
    else
      echo "$(date +"%Y-%m-%d %H:%M:%S") - Nenhum backup automático encontrado para o cluster $cluster na região $region."
    fi    
  done
done

