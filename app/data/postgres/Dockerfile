FROM postgres:10.5
COPY tailwind.sql /docker-entrypoint-initdb.d/seed.sql
ENV POSTGRES_USER=tt_user POSTGRES_PASSWORD=tt_password POSTGRES_DB=tt
EXPOSE 5432