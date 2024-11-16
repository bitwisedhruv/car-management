from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from models import Car
from schemas import CarCreate, CarUpdate
from database import get_db
from crud import (
    create_car,
    delete_car,
    get_cars,
    get_cars_by_user,
    search_cars,
    update_car,
)

router = APIRouter()


@router.post("/cars")
def create_car_endpoint(
    car: CarCreate, db: Session = Depends(get_db), user_id: int = 1
):

    return create_car(db=db, car=car, user_id=user_id)


@router.get("/cars")
def read_cars_by_user(db: Session = Depends(get_db), user_id: int = 1):
    return get_cars_by_user(db=db, user_id=user_id)


@router.get("/all-cars")
def read_cars(db: Session = Depends(get_db)):
    return get_cars(db=db)


@router.put("/cars/{car_id}")
def update_car_endpoint(
    car_id: int, car: CarUpdate, db: Session = Depends(get_db), user_id: int = 1
):
    # Ensure the car belongs to the logged-in user
    db_car = db.query(Car).filter(Car.id == car_id, Car.user_id == user_id).first()
    if not db_car:
        raise HTTPException(status_code=403, detail="Not authorized to update this car")

    car_data = car.dict(exclude_unset=True)
    return update_car(db=db, car_id=car_id, car_update=car_data)


@router.delete("/cars/{car_id}")
def delete_car_endpoint(car_id: int, db: Session = Depends(get_db), user_id: int = 1):
    # Ensure the car belongs to the logged-in user
    db_car = db.query(Car).filter(Car.id == car_id, Car.user_id == user_id).first()
    if not db_car:
        raise HTTPException(status_code=403, detail="Not authorized to delete this car")

    return delete_car(db=db, car_id=car_id)


@router.get("/search")
def search_car(query: str, db: Session = Depends(get_db)):
    return search_cars(db=db, query=query)
