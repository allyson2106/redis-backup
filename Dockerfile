# Define a imagem do container
FROM amazonlinux:2

# Instala as dependências necessárias
RUN yum update -y && \
    yum install -y awscli cronie jq && \
    yum clean all && \
    rm -rf /var/cache/yum/*
# Define o diretório de trabalho
WORKDIR /usr/local/bin
# Copia o script de backup
COPY redis.sh .

# Define as permissões do script
RUN chmod +x redis.sh


# Define as variáveis de ambiente
ENV S3_BUCKET_NAME=
ENV REGION=

# Define o comando padrão que será executado quando o contêiner for iniciado
CMD ./redis.sh
