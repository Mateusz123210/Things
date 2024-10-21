from app import models
from app.schemas import *
from app.decorators.database import db

# @db
# def get_all_users(db):
#     return db.query(models.User).all()

# @db
# def get_user(user_id: int, db):
#     return db.query(models.User).filter(models.User.id == user_id).first()

# @db 
# def get_available_callers1(user_id, db):
#     return db.query(models.Key).filter(models.Key.first_user_id == user_id).all()

# @db 
# def get_available_callers2(user_id, db):
#     return db.query(models.Key).filter(models.Key.second_user_id == user_id).all()

@db
def get_user_by_email(email: str, db):
    return db.query(models.User).filter(models.User.email == email).first()

# @db
# def get_all_tokens(db):
#     return db.query(models.Token).all()

# @db
# def get_token(access_token, db):
#     return db.query(models.Token).filter(models.Token.access_token == access_token).first()

# @db
# def check_user_password(email: str, password: str, db):
#     return db.query(models.User).filter(models.User.email == email, models.User.password == password).first()

@db
def create_user(email, password, last_login_attempt, db):
    db_user = models.User(email=email, password=password, last_login_attempt=last_login_attempt)
    db.add(db_user)
    db.flush()

# @db
# def create_user_tokens(db_user: models.User, access_token: str, refresh_token: str,
#                        access_token_expiration_time: datetime, refresh_token_expiration_time: datetime, db):
#     db_token = models.Token(access_token=access_token, refresh_token=refresh_token, 
#                             access_token_expiration_time=access_token_expiration_time,
#                             refresh_token_expiration_time=refresh_token_expiration_time, user_id=db_user.id)
#     db.add(db_token)
#     db.flush()
#     return db_token

# @db
# def create_user_tokens2(db_user: models.User, access_token: str, refresh_token: str,
#                        access_token_expiration_time: datetime, refresh_token_expiration_time: datetime, db,
#                        verification_code: str, verification_code_expiration_time: datetime,
#                        verification_code_type: str):
#     db_token = models.Token(access_token=access_token, refresh_token=refresh_token, 
#                         access_token_expiration_time=access_token_expiration_time,
#                         refresh_token_expiration_time=refresh_token_expiration_time, user_id=db_user,
#                         verification_code=verification_code, 
#                         verification_code_expiration_time=verification_code_expiration_time,
#                         verification_code_type=verification_code_type)
#     db.add(db_token)
#     db.flush()
#     return db_token

# @db
# def create_user_tokens3(db_user: models.User, access_token: str,
#                        access_token_expiration_time: datetime, refresh_token_expiration_time: datetime, db,
#                        verification_code: str, verification_code_expiration_time: datetime,
#                        verification_code_type: str, logged: bool, new_password : str):
#     db_token = models.Token(access_token=access_token, refresh_token=None, 
#                         access_token_expiration_time=access_token_expiration_time,
#                         refresh_token_expiration_time=None, user_id=db_user.id,
#                         verification_code=verification_code, 
#                         verification_code_expiration_time=verification_code_expiration_time,
#                         verification_code_type=verification_code_type, logged=logged,
#                         new_password=new_password)
#     db.add(db_token)
#     db.flush()
#     return db_token

# @db
# def delete_user(user, db):
#     user_tokens = db.query(models.Token).filter(models.Token.user_id==user.id)
#     for token in user_tokens:
#         db.delete(token)
#     db.delete(user)
#     db.flush()

# @db
# def delete_user_with_keys(user, db):
#     user_tokens = db.query(models.Token).filter(models.Token.user_id==user.id)
#     for token in user_tokens:
#         db.delete(token)
    
#     user_keys = db.query(models.Key).filter(models.Key.first_user_id==user.id)
#     for key in user_keys:
#         db.delete(key)
    
#     user_keys = db.query(models.Key).filter(models.Key.second_user_id==user.id)
#     for key in user_keys:
#         db.delete(key)

#     db.delete(user)
#     db.flush()

# @db
# def add_key(first_user, second_user, aes_key, initialization_vector, db):
#     db_key = models.Key(first_user_id = first_user.id,
#     second_user_id = second_user.id,
#     aes_key = aes_key,
#     initialization_vector = initialization_vector)
#     db.add(db_key)
#     db.flush()

# @db
# def get_key(first_user, second_user, db):
#     return db.query(models.Key).filter(models.Key.first_user_id==first_user.id, 
#                                        models.Key.second_user_id==second_user.id).first()

# @db
# def delete_token(token: models.Token, db):
#     db.delete(token)
#     db.flush()

# @db
# def delete_user_tokens(user, db):
#     user_tokens = db.query(models.Token).filter(models.Token.user_id==user.id)
#     for token in user_tokens:
#         db.delete(token)
#     db.flush()

# @db
# def get_user_tokens(user, db):
#     return db.query(models.Token).filter(models.Token.user_id == user.id).all()

# @db
# def activate_user(user, db):
#     db.query(models.User).filter(models.User.email==user.email).update({"is_active": True,
#         "registration_confirmation_code": None,
#         "registration_confirmation_code_expiration_time": None,
#         "registration_confirmation_code_enter_attempts": 0})
#     db.flush()

# @db
# def update_token(found_token, new_token, db):
#     db.query(models.Token).filter(models.Token.id==found_token.id).update({"access_token": new_token.access_token, 
#                                 "access_token_expiration_time": new_token.access_token_expiration_time,
#                                 "refresh_token": new_token.refresh_token, 
#                                 "refresh_token_expiration_time": new_token.refresh_token_expiration_time})
#     db.flush()

# @db
# def update_token_after_login(found_token, access_token: str, access_token_expiration_time: datetime,
#                             refresh_token: str, refresh_token_expiration_time: datetime, db):
#     db.query(models.Token).filter(models.Token.id==found_token.id).update({"access_token": access_token, 
#                                 "access_token_expiration_time": access_token_expiration_time,
#                                 "refresh_token": refresh_token, 
#                                 "refresh_token_expiration_time": refresh_token_expiration_time,
#                                 "verification_code": None, 
#                                 "verification_code_expiration_time": None,
#                                 "verification_code_enter_attempts": 0, "verification_code_type": None,
#                                 "logged": True})
#     db.flush()



