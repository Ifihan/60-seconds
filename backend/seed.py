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
            "Public key cryptography in plain English",
            "Why garbage collection exists",
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
            "Event-driven architecture",
            "Monolith vs microservices tradeoffs",
            "Consistent hashing explained",
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
            "How a neural network actually learns",
            "Precision vs recall — when each matters",
            "Why more data beats a better algorithm",
        ],
    },
    {
        "name": "Artificial Intelligence",
        "topics": [
            "How large language models generate text",
            "Reinforcement learning from human feedback (RLHF)",
            "Why hallucinations happen in LLMs",
            "The alignment problem explained simply",
            "AI agents: what they are and how they work",
            "RAG: retrieval-augmented generation",
            "Why context window size matters",
            "AI safety vs AI capabilities — the tension",
            "Emergent behavior in large models",
        ],
    },
    {
        "name": "Philosophy",
        "topics": [
            "The trolley problem and what it reveals",
            "Free will vs determinism",
            "What makes something morally wrong?",
            "The ship of Theseus and personal identity",
            "Plato's cave allegory",
            "Is consciousness just computation?",
            "Utilitarianism vs deontology — key difference",
            "The problem of induction",
            "What Nietzsche meant by 'God is dead'",
            "Can we ever truly know anything?",
        ],
    },
    {
        "name": "Economics",
        "topics": [
            "Why inflation happens",
            "Supply and demand — the core insight",
            "What GDP actually measures (and misses)",
            "How central banks control interest rates",
            "Game theory in everyday decisions",
            "The prisoner's dilemma explained",
            "Why comparative advantage drives trade",
            "What a recession technically is",
            "Behavioral economics: people aren't rational",
            "The gig economy and what it changes",
        ],
    },
    {
        "name": "Psychology",
        "topics": [
            "Cognitive dissonance and how we resolve it",
            "The Dunning-Kruger effect explained",
            "Why habits form and how to change them",
            "The psychology of loss aversion",
            "Confirmation bias in everyday thinking",
            "What flow state actually is",
            "Intrinsic vs extrinsic motivation",
            "How sleep affects memory consolidation",
            "The bystander effect and diffusion of responsibility",
            "Why stress impairs decision-making",
        ],
    },
    {
        "name": "Neuroscience",
        "topics": [
            "How neurons communicate",
            "What dopamine actually does (it's not just pleasure)",
            "The difference between short and long-term memory",
            "Neuroplasticity — what it means and what it doesn't",
            "Why we dream",
            "How fear is processed in the brain",
            "The role of the prefrontal cortex",
            "What happens in the brain during meditation",
            "Why chronic stress physically changes the brain",
        ],
    },
    {
        "name": "Physics",
        "topics": [
            "Why nothing can travel faster than light",
            "What entropy actually means",
            "How quantum superposition works",
            "The double-slit experiment explained",
            "Why time slows down at high speeds",
            "What a black hole event horizon is",
            "The difference between mass and weight",
            "How nuclear fission releases energy",
            "Dark matter — what we know and don't know",
            "Why the sky is blue",
        ],
    },
    {
        "name": "Climate & Environment",
        "topics": [
            "How the greenhouse effect works",
            "Why carbon dioxide is the main focus",
            "Ocean acidification explained",
            "The difference between weather and climate",
            "How deforestation affects rainfall patterns",
            "What tipping points mean in climate science",
            "Why biodiversity loss matters for humans",
            "How carbon capture works",
            "The water cycle and why it's changing",
            "What net zero actually means",
        ],
    },
    {
        "name": "History",
        "topics": [
            "Why the Roman Empire fell",
            "The causes of World War I",
            "How the Cold War shaped the modern world",
            "The Industrial Revolution's real impact",
            "Why the printing press changed everything",
            "The origins of democracy in Athens",
            "How colonialism still shapes geopolitics",
            "The significance of the Magna Carta",
            "What caused the Great Depression",
            "How the internet changed power structures",
        ],
    },
    {
        "name": "Geopolitics",
        "topics": [
            "Why geography shapes national strategy",
            "What NATO is and why it exists",
            "The US-China rivalry explained",
            "Why the Middle East is geopolitically significant",
            "How sanctions actually work",
            "What soft power is and why it matters",
            "The Belt and Road Initiative",
            "Why small nations punch above their weight",
            "How nuclear deterrence works",
            "What drives resource conflicts",
        ],
    },
    {
        "name": "Entrepreneurship",
        "topics": [
            "Product-market fit — how to know when you have it",
            "Why most startups fail",
            "The difference between a vision and a strategy",
            "How venture capital actually works",
            "Why distribution beats product in the early days",
            "What a moat is in business",
            "The lean startup methodology",
            "Why pricing is a positioning decision",
            "How to think about burn rate",
            "Why the second founder problem is real",
        ],
    },
    {
        "name": "Mathematics",
        "topics": [
            "Why division by zero is undefined",
            "What infinity means in mathematics",
            "The beauty of prime numbers",
            "How Bayes' theorem changes how you think",
            "What a proof actually is",
            "Why 0.999... equals 1",
            "The Monty Hall problem explained",
            "What topology studies",
            "How RSA encryption relies on number theory",
            "The birthday paradox and probability intuition",
        ],
    },
    {
        "name": "Biology",
        "topics": [
            "How DNA replication works",
            "Why evolution is a theory (in the scientific sense)",
            "What CRISPR actually does",
            "How vaccines train the immune system",
            "The difference between viruses and bacteria",
            "Why cells divide — and why they stop",
            "How natural selection differs from random mutation",
            "What mitochondria actually do",
            "The gut microbiome and why it matters",
            "How antibiotic resistance develops",
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
