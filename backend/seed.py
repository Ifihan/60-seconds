import asyncio
import secrets

from sqlalchemy import select
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine

from app.config import settings
from app.models.area import Area
from app.models.topic import Topic
from app.models.user import User
from app.models.user_area import UserArea
from app.utils.hashing import hash_password

SEED_EMAIL = "seed@60seconds.dev"

SEED_DATA = [
    {
        "name": "Computer Science",
        "topics": [
            "TCP/IP and how the internet routes data",
            "Memory management: stack vs heap",
            "Binary, bytes, and bitwise operations",
            "What happens when you type a URL",
            "How a database index works",
            "REST vs GraphQL explained simply",
            "Concurrency vs parallelism",
            "How the browser renders a page",
        ],
    },
    {
        "name": "System Design",
        "topics": [
            "CAP theorem",
            "Load balancing strategies",
            "Database sharding",
            "Caching layers (L1, L2, CDN)",
            "Message queues and async processing",
            "API rate limiting",
        ],
    },
    {
        "name": "Machine Learning",
        "topics": [
            "Gradient descent in plain English",
            "What embeddings are and why they matter",
            "The attention mechanism in transformers",
            "Overfitting vs underfitting",
            "Bias-variance tradeoff",
            "Few-shot learning overview",
        ],
    },
]


async def seed_areas(db):
    for area_data in SEED_DATA:
        existing = await db.execute(select(Area).where(Area.name == area_data["name"]))
        area = existing.scalar_one_or_none()
        if not area:
            area = Area(name=area_data["name"])
            db.add(area)
            await db.flush()

        for topic_name in area_data["topics"]:
            existing_topic = await db.execute(
                select(Topic).where(Topic.area_id == area.id, Topic.name == topic_name)
            )
            if not existing_topic.scalar_one_or_none():
                db.add(Topic(name=topic_name, area_id=area.id))

    await db.commit()
    print("Seeded global areas and topics.")


async def seed_dev_user(db):
    existing = await db.execute(select(User).where(User.email == SEED_EMAIL))
    if existing.scalar_one_or_none():
        print(f"Dev user {SEED_EMAIL} already exists, skipping.")
        return

    seed_password = secrets.token_urlsafe(24)
    user = User(email=SEED_EMAIL, password=hash_password(seed_password))
    db.add(user)
    await db.flush()

    areas_result = await db.execute(select(Area))
    for area in areas_result.scalars().all():
        db.add(UserArea(user_id=user.id, area_id=area.id))

    await db.commit()
    print(f"Seeded dev user: {SEED_EMAIL} / {seed_password}")


async def seed():
    engine = create_async_engine(settings.database_url, connect_args={"statement_cache_size": 0}, echo=False)
    SessionLocal = async_sessionmaker(engine, expire_on_commit=False)

    async with SessionLocal() as db:
        await seed_areas(db)
        if settings.environment != "production":
            await seed_dev_user(db)

    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(seed())
