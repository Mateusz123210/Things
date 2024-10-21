from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

SQLALCHEMY_DATABASE_URL = 'postgresql+psycopg2://things_admin:Admin_123@postgrethings.postgres.database.azure.com/postgres'

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={'sslmode':'require'}
)
SessionMaker = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()