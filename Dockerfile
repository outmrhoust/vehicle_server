FROM gcr.io/distroless/static-debian12
COPY ./dist/main /
WORKDIR /
ENTRYPOINT ["/main"]
