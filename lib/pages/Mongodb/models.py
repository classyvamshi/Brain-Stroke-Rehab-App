from pydantic import BaseModel
from typing import Optional, Dict

class WaterData(BaseModel):
    water_consumed: float
    last_seen: str
    last_reset_date: str
    water_target: float

class MealTargets(BaseModel):
    breakfast_calories_target: float
    lunch_calories_target: float
    snack_calories_target: float
    dinner_calories_target: float

class UserData(BaseModel):
    uid: str
    water_data: WaterData
    meal_targets: MealTargets

class BodyMeasurement(BaseModel):
    gender: str
    height: float
    weight: float
    age: int
    goal: str
    activity_level: str
    bmi: float
    last_measured: str

class UserBodyData(BaseModel):
    uid: str
    body_measurement: BodyMeasurement