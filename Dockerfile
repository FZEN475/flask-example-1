FROM alpine:latest as ansible 
#нужен ли тут алиас as ansible ?

RUN apk add --update --no-cache python3 py3-pip py3-flask 
# установка библиотек рекомендуется с указанием версий для стабильности.
# библиотеки питона я бы ставил через pip install -r requirements.txt

COPY ./src /src
# ADD deprecated, используй COPY
ADD ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# entrypoint.sh - не очень прозрачно что за баш. Я бы предложил просто использовать ENTRIPOINT ["python", /src/hello.py]