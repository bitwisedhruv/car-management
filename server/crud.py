from fastapi import HTTPException
from sqlalchemy import or_, func
from sqlalchemy.orm import Session
from models import User, Car
from schemas import CarCreate
from auth import get_password_hash, verify_password


def create_user(db: Session, name: str, email: str, password: str):
    hashed_password = get_password_hash(password)
    db_user = User(name=name, email=email, password=hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user


def authenticate_user(db: Session, email: str, password: str):
    user = db.query(User).filter(User.email == email).first()
    if not user or not verify_password(password, user.password):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    return user


def create_car(db: Session, car: CarCreate, user_id: int):
    db_car = Car(**car.dict(), user_id=user_id)
    db.add(db_car)
    db.commit()
    db.refresh(db_car)
    return db_car


def get_cars_by_user(db: Session, user_id: int):
    return db.query(Car).filter(Car.user_id == user_id).all()


def get_cars(db: Session):
    return db.query(Car).all()


def search_cars(db: Session, query: str):
    query_lower = query.lower()
    return (
        db.query(Car)
        .filter(
            or_(
                func.lower(Car.title).contains(query_lower),
                func.lower(Car.description).contains(query_lower),
                func.lower(Car.tags).contains(query_lower),
            ),
        )
        .all()
    )


def update_car(db: Session, car_id: int, car_update: dict):
    db_car = db.query(Car).filter(Car.id == car_id).first()
    if not db_car:
        raise HTTPException(status_code=404, detail="Car not found")

    for key, value in car_update.items():
        if value is not None:
            setattr(db_car, key, value)

    db.commit()
    db.refresh(db_car)
    return db_car


def delete_car(db: Session, car_id: int):
    db_car = db.query(Car).filter(Car.id == car_id).first()
    if not db_car:
        raise HTTPException(status_code=404, detail="Car not found")

    db.delete(db_car)
    db.commit()
    return {"message": "Car deleted successfully"}
