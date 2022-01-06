# Build stage
FROM golang:1.16-alpine3.13 AS builder
WORKDIR /app
COPY . .
RUN go build -o main main.go
# 分阶段构建，将Dockerfile 转换为多级
# 包含所有的我们的文件，而我们只运行go build命令后的输出二进制文件，我们不需要其他的东西，甚至是原始的golang代码，
# 因此，如果我们可以仅使用二进制文件生成图像，那么他的大小将非常小
RUN apk add curl
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.15.1/migrate.linux-amd64.tar.gz | tar xvz

# Run stage
FROM alpine:3.13
WORKDIR /app
COPY --from=builder /app/main .
COPY --from=builder /app/migrate ./migrate
COPY app.env .
COPY start.sh .
COPY wait-for.sh .
COPY db/migration ./migration

EXPOSE 8080
CMD [ "/app/main" ]
ENTRYPOINT [ "/app/start.sh"]