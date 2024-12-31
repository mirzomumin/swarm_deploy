# # # # # # # #
#             #
# BUILD STAGE #
#             #
# # # # # # # #

FROM python:3.13.0-slim as build-stage

ARG TEMP=/tmp
WORKDIR ${TEMP}

# Install necessary packages, including curl
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 - \
    && mv /root/.local/bin/poetry /usr/local/bin/poetry

# Verify Poetry installation
RUN poetry --version

# Copy project dependencies
COPY poetry.lock pyproject.toml ${TEMP}/

# Install project dependencies
RUN poetry config virtualenvs.create false \
    && poetry install --no-root

# # # # # # # #
#             #
# FINAL STAGE #
#             #
# # # # # # # #

FROM python:3.13.0-slim as final-stage

#ARG USERNAME=mohirpay
ARG APP_HOME=/code
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

WORKDIR ${APP_HOME}

# create user
#RUN #groupadd -r mohirpay \
##    && useradd -r -g mohirpay mohirpay

# Install packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential \
    gettext \
    vim \
    curl \
    binutils \
    libproj-dev \
    gdal-bin \
    libpq-dev \
    postgresql-client \
    && apt-get clean \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build-stage /usr/local/lib/python3.13/site-packages/ /usr/local/lib/python3.13/site-packages/
COPY --from=build-stage /usr/local/bin/ /usr/local/bin/

#RUN mkdir /var/log/django/
#RUN touch /var/log/django/error.log
#RUN mkdir /var/log/celery/
#RUN touch /var/log/celery/celery.log

# Add scripts
COPY command.sh ${APP_HOME}/command.sh

RUN chmod +X ${APP_HOME}/command.sh

#RUN mkdir -p ${APP_HOME}/static ${APP_HOME}/media
#    && chown -R ${USERNAME}:${USERNAME} ${APP_HOME}/

# Copy project
COPY . ${APP_HOME}

#RUN chown -R mohirpay:mohirpay ${APP_HOME}/

# change to the app user
#USER mohirpay