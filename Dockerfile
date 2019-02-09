FROM microsoft/dotnet:2.2-sdk-alpine AS buildcore
WORKDIR /app

RUN apk --no-cache add nodejs nodejs-npm

COPY . .

# build API
RUN dotnet restore ./api
RUN dotnet build -c Release ./api
RUN dotnet publish -c Release -o /app/deploy/api ./api

#build CLIENT
WORKDIR /app/client
RUN npm install
RUN npm run-script build


FROM microsoft/dotnet:2.2-aspnetcore-runtime-alpine AS runtime
WORKDIR /app

EXPOSE 80
COPY --from=buildcore /app/deploy/api ./api
COPY --from=buildcore /app/client/build ./client

ENTRYPOINT [ "dotnet", "api/api.dll" ]
