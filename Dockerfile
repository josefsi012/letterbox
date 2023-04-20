# Dockerfile References: https://docs.docker.com/engine/reference/builder/

# Letterbox GitHub: https://github.com/bcl/letterbox

# To build image:
#   $ docker build -t letterbox .

# To run container:
#   $ docker run -p 2525:25 --name letterbox -v ${PWD}/config:/config -v ${PWD}/data:/data letterbox

# Start from the latest golang base image
FROM golang:latest

# Path to configutation file
ENV CONFIG=/config/letterbox.toml

# Host IP or name to bind to
ENV HOST=0.0.0.0

# Path to the top level of the user Maildirs
ENV MAILDIRS="/data/maildirs"

# Port to bind to
ENV PORT=25

ENV APP_DIR=/app PUID=1000 PGID=1000 UMASK=002 TZ=Etc/UTC ARGS=

# Set the Current Working Directory inside the container
WORKDIR ${APP_DIR}

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies. Dependencies will be cached if the go.mod and go.sum files are not changed
RUN go mod download

# Copy the source from the current directory to the Working Directory inside the container
COPY main.go Makefile ./

# Build the Go app
RUN make

#RUN groupadd -g -r user && useradd -r -g user user
#USER user
USER ${PUID}:${PGID}

# Expose port to the outside world
EXPOSE ${PORT}

# Volume
VOLUME ["/config", "/data"]

# Command to run the executable
CMD ["sh", "-c", "./letterbox -config ${CONFIG} -host ${HOST} -maildirs ${MAILDIRS} -port ${PORT} -log /dev/stdout"]
