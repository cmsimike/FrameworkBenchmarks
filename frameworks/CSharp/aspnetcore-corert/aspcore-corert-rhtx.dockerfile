FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS build
RUN echo "deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.9 main" | tee /etc/apt/sources.list.d/llvm.list
RUN wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | apt-key add -
RUN apt-get update
RUN apt-get -yqq install cmake clang-3.9 libicu57 libunwind8 uuid-dev libcurl4-openssl-dev zlib1g-dev libkrb5-dev
RUN wget https://download.visualstudio.microsoft.com/download/pr/a0e368ac-7161-4bde-a139-1a3ef5a82bbe/439cdbb58950916d3718771c5d986c35/dotnet-sdk-3.0.100-preview8-013656-linux-x64.tar.gz
RUN mkdir -p /dotnet
RUN tar zxf dotnet-sdk-3.0.100-preview8-013656-linux-x64.tar.gz -C /dotnet
WORKDIR /app
COPY PlatformBenchmarks .
RUN /dotnet/dotnet publish -c Release -o out -r linux-x64

FROM mcr.microsoft.com/dotnet/core/aspnet:3.0 AS runtime
WORKDIR /app
COPY --from=build /app/out ./

ENTRYPOINT ["./PlatformBenchmarks", "--server.urls=http://+:8080", "KestrelTransport=LinuxTransport"]
