from sqlalchemy import Column, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from database import Base


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    email = Column(String, unique=True, index=True)
    password = Column(String)


class Car(Base):
    __tablename__ = "cars"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    description = Column(Text)
    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("User")
    images = Column(String)  # Comma-separated URLs for images
    tags = Column(String)  # Comma-separated tags (car_type, company, etc.)
