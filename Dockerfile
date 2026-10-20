# Etapa 1 (builder)
FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src/ ./src/
RUN mvn clean package -DskipTests

# Etapa 2 (runtime)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
# Crear usuario sin privilegios
RUN addgroup -S sensorgroup && adduser -S -u 10001 sensor_user -G sensorgroup
# Copiar el jar
COPY --from=builder /app/target/*.jar /app/app.jar
RUN chown -R sensor_user:sensorgroup /app

ARG STUDENT_ID
ENV OPERATOR_ID=${STUDENT_ID}

USER sensor_user
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
