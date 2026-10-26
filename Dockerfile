FROM alpine:3.22

WORKDIR /app

COPY hello.sh .

RUN chmod +x hello.sh

CMD ["./hello.sh"]
