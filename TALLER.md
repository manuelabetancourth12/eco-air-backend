# Reporte Forense - Taller Docker

## Reto 2: Auditoría Forense y Comprobación de Vulnerabilidades
**1. Verificación del Desacoplamiento de Capas:**
**Comando:** `docker history --human --format "table {{.Size}}\t{{.CreatedBy}}" eco-air-backend:1.0.0`
**Evidencia:**
SIZE      CREATED BY
0B        ENTRYPOINT ["java" "-jar" "/app/app.jar"]
0B        USER sensor_user
0B        ENV OPERATOR_ID=847073
0B        ARG STUDENT_ID=847073
19MB      RUN /bin/sh -c chown -R sensor_user:sensorgr…
19MB      COPY /app/target/*.jar /app/app.jar # buildk…
41kB      RUN /bin/sh -c addgroup -S sensorgroup && ad…
8.19kB    WORKDIR /app
0B        ENTRYPOINT ["/__cacert_entrypoint.sh"]
12.3kB    COPY --chmod=755 entrypoint.sh /__cacert_ent…
12.3kB    RUN /bin/sh -c set -eux;     echo "Verifying…
141MB     RUN /bin/sh -c set -eux;     ARCH="$(apk --p…
0B        ENV JAVA_VERSION=jdk-17.0.20.1+1
44MB      RUN /bin/sh -c set -eux;     apk add --no-ca…
0B        ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_AL…
0B        ENV PATH=/opt/java/openjdk/bin:/usr/local/sb…
0B        ENV JAVA_HOME=/opt/java/openjdk
0B        CMD ["/bin/sh"]
9.08MB    ADD alpine-minirootfs-3.24.2-x86_64.tar.gz /…)

**2. Inspección del Proceso del Host:**
**Comando:** `docker top eco_air_active -o pid,user,comm`
**Evidencia:**
PID                 USER                COMMAND
1137                10001               java
**Explicación:** Se demuestra que el proceso java no se ejecuta como root, sino bajo el identificador seguro del usuario sensor_user con UID 10001.

**3. Test de Penetración (Inmutabilidad de Runtime):**
**Comando:** `docker exec eco_air_active touch /etc/crontab_fake`
**Evidencia:** 
touch: cannot touch '/etc/crontab_fake': Permission denied
**Explicación:** El sistema restringe la escritura, demostrando que el contenedor fue configurado correctamente con un usuario sin privilegios.

**4. Auditoría de Artefactos de Desarrollo:**
**Comando:** `docker exec eco_air_active which mvn` y `docker exec eco_air_active find / -name "*.java" 2> $null`
**Evidencia:** Ambas salidas retornaron vacías.
**Explicación:** Se confirma que la imagen de producción está limpia de herramientas de compilación y código fuente.

## Reto 3: Calibración de cgroups y Captura del Asesino OOM
**1. Inducción del Colapso por Memoria (OOMKilled):**
**Comando:** `docker inspect eco_air_crash_2 --format='Status: {{.State.Status}} | ExitCode: {{.State.ExitCode}} | OOMKilled: {{.State.OOMKilled}}'`
**Evidencia:** Status: exited | ExitCode: 137 | OOMKilled: true
**Explicación:** Al asfixiar el contenedor limitándolo a 16MB de memoria, el kernel eliminó el proceso exitosamente.

**2. Calibración del Límite Operativo Mínimo:**
Se comprobó que el contenedor arranca de forma estable con un límite de memoria de 256m (`JAVA_OPTS="-Xms256m -Xmx256m"`).

## Tabla de Identidad Final
* **Hash de la imagen:** 
**comando:** `docker inspect --format='{{.Id}}' eco-air-backend:1.0`
**evidencia**
sha256:c16a1351794bd58f768e12cd01b193313bdaf8f4e8ec932568ccc4cae74f8ab3

* **Variable de entorno inyectada:
**comando** `docker exec eco_air_active sh -c "env | grep OPERATOR_ID"`
**evidencia** 
OPERATOR_ID=847073

* **Consumo final calibrado:** 
**comando** `docker stats --no-stream eco_air_active`
**evidencia**
CONTAINER ID   NAME             CPU %     MEM USAGE / LIMIT    MEM %     NET I/O         BLOCK I/O        PIDS
63e2eb874a47   eco_air_active   0.19%     146.5MiB / 11.5GiB   1.24%     1.42kB / 126B   3.57MB / 852kB   48