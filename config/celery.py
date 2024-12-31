import os

from celery import Celery
from celery.schedules import crontab
from django.conf import settings

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

app = Celery("config")
app.autodiscover_tasks()

BROKER_URL = f"redis://{settings.REDIS_HOST}:{settings.REDIS_PORT}/0"  # noqa

app.conf.update(
    broker_url=BROKER_URL,
    result_backend=BROKER_URL,
    accept_content=["json"],
    task_serializer="json",
    result_serializer="json",
    task_always_eager=not BROKER_URL,
    task_ignore_result=True,
    task_store_errors_even_if_ignored=True,
    enable_utc=True,
    timezone="Asia/Tashkent",
    broker_connection_retry_on_startup=True,
    task_track_started=True,
    worker_send_task_events=True,
    task_send_sent_event=True,
    # task_annotations={"*": {"rate_limit": "10/m"}},
    # task_default_queue='normal',
    # task_default_exchange='normal',
    # task_default_routing_key='normal',
)

schedule_crontab = {"schedule": crontab(hour="*/2", minute="0")}

if settings.DEBUG:
    schedule_crontab = {"schedule": crontab(minute="*/1")}

app.conf.beat_schedule = {
    "subtract-by-schedule": {
        "task": "config.celery.subtract",
        # a job is scheduled to run on the every two hours on production
        **schedule_crontab,
    }
}


@app.task
def add(x: int | float, y: int | float) -> int:
    return x + y


@app.task
def subtract(x: int | float = 5, y: int | float = 3) -> int | float:
    return x - y
