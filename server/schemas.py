from typing import List, Optional
from pydantic import BaseModel


class UserCreate(BaseModel):
    name: str
    email: str
    password: str


class UserLogin(BaseModel):
    email: str
    password: str


class CarBase(BaseModel):
    title: str
    description: str
    images: Optional[List[str]] = None
    tags: Optional[List[str]] = None


class CarCreate(CarBase):
    pass


class CarUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    images: Optional[List[str]] = None
    tags: Optional[List[str]] = None


class Car(CarBase):
    id: int

    class Config:
        orm_mode = True
        extra = "forbid"
