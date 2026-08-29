FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
# Aici adăugăm calea către folderul în care se află proiectul:
COPY ["CabanaBookingApi/CabanaBookingApi.csproj", "CabanaBookingApi/"]
RUN dotnet restore "CabanaBookingApi/CabanaBookingApi.csproj"
COPY . .
WORKDIR "/src/CabanaBookingApi"
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "CabanaBookingApi.dll"]