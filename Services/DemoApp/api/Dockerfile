# docker build -t mgrast/demo-app-api .

# e.g. DOCKER_BINARY="${HOME}/git/Skyport2/live-data/docker-17.12.0-ce"
# docker run --rm -p 5000:5000  -v ${DOCKER_BINARY}:/usr/local/bin/docker -v /var/run/docker.sock:/var/run/docker.sock  mgrast/demo-app-api

# development only:  docker run --rm -p 5000:5000  -v ${DOCKER_BINARY}:/usr/local/bin/docker -v /var/run/docker.sock:/var/run/docker.sock -v `pwd`:/usr/src/app --env CWL_DIR=${HOME}/git/Skyport2/CWL/ mgrast/demo-app-api gunicorn -w1 -b 0.0.0.0:5000  --error-logfile - --log-level debug --capture-output app:app


FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["gunicorn", "-w", "1", "-b", "0.0.0.0:5000", "app:app"]
