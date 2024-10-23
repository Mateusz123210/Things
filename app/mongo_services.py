from app.mongo_database import collection_categories, collection_products, collection_notes
from fastapi import HTTPException
from app.decorators.mongo_database import mongo_transactional
from app.decorators.database import transactional
from app import deps
from app.schemas import *

@mongo_transactional
@transactional
def get_user_categories(access_token, email, session):
    deps.validate_user_token(access_token, email)

 

    pass
#     found_conversation = collection_name.find_one({"first_user": data["first_user"], "second_user": data["second_user"]},
#                                                   session=session)
#     if found_conversation:
#         list1 = found_conversation["message"]
#         return {"messages": list1}
#     else:
#         found_conversation = collection_name.find_one({"first_user": data["second_user"], "second_user": data["first_user"]},
#                                                       session=session)
#         if found_conversation:
#             list1 = found_conversation["message"]
#             reversed_list_for_second_caller = []
#             for i in list1:
#                 dictionary = i
#                 for j in dictionary:
#                     if dictionary[j] == "from_first":
#                         dictionary[j] = "from_second"
#                     else:
#                         dictionary[j] = "from_first"
#                 reversed_list_for_second_caller.append(dictionary)
#             return {"messages": reversed_list_for_second_caller}
#         else:
#             raise HTTPException(status_code=204)

@mongo_transactional
@transactional
def add_category(access_token, email, data: CategoryAdd, session):

    deps.validate_user_token(access_token, email)

    if len(data.name) == 0:
        raise HTTPException(status_code=400, detail="Category field is empty!")

    found_category = collection_categories.find_one({"name": data.name}, session=session)

    if found_category:
        raise HTTPException(status_code=400, detail="You already have category with this name!")





#     if len(data["message"]) == 0:
#         raise HTTPException(status_code=400, detail="You cannot send empty message!")
#     found_conversation = collection_name.find_one({"first_user": data["first_user"], "second_user": data["second_user"]}, 
#                                                   session=session)
#     if found_conversation:
#         list1 = found_conversation["message"]
#         list1.append({data["message"]: "from_first"})
#         filter = { '_id': found_conversation["_id"] }
#         new_values = { "$set": { 'message': list1 } }
#         collection_name.update_one(filter, new_values, session=session)
#     else:
#         found_conversation = collection_name.find_one({"first_user": data["second_user"], "second_user": data["first_user"]},
#                                                       session=session)
#         if found_conversation:
#             list1 = found_conversation["message"]
#             list1.append({data["message"]: "from_second"})
#             filter = { '_id': found_conversation["_id"] }
#             new_values = { "$set": { 'message': list1 } }
#             collection_name.update_one(filter, new_values, session=session)
#         else:
#             insert_data = {"first_user": data["first_user"], "second_user": data["second_user"]}
#             insert_data["message"] = [{data["message"]: "from_first"}]
#             collection_name.insert_one(insert_data, session=session)

#     return {"message": "Message sent!"}

# @transactional
# def delete_messages(data, session):
#     found_conversation = collection_name.find_one_and_delete({"first_user": data["user"]}, session=session)
#     if found_conversation:
#         return {"message": "User messages has been deleted!"}
#     else:
#         found_conversation = collection_name.find_one_and_delete({"second_user": data["user"]}, session=session)
#         if found_conversation:
#             return {"message": "User messages has been deleted!"}
#         else:
#             return {"message": "User had no sended messages!"}

@mongo_transactional
@transactional
def edit_category(access_token, email, data, session):
    deps.validate_user_token(access_token, email)
    print("val")

@mongo_transactional
@transactional
def delete_category(access_token, email, data, session):
    deps.validate_user_token(access_token, email)
    print("val")

@mongo_transactional
@transactional
def get_category_products(access_token, email, data, session):
    deps.validate_user_token(access_token, email)
    print("val")

@mongo_transactional
@transactional
def get_product(access_token, email, data, session):
    deps.validate_user_token(access_token, email)
    print("val")

@mongo_transactional
@transactional
def add_product(access_token, email, data, session):
    deps.validate_user_token(access_token, email)
    print("val")

@mongo_transactional
@transactional
def edit_product(access_token, email, data, session):
    deps.validate_user_token(access_token, email)
    print("val")

@mongo_transactional
@transactional
def delete_product(access_token, email, data, session):
    deps.validate_user_token(access_token, email)
    print("val")

@mongo_transactional
@transactional
def get_notes(access_token, email, session):
    deps.validate_user_token(access_token, email)
    print("val")

@mongo_transactional
@transactional
def get_note(access_token, email, data, session):
    deps.validate_user_token(access_token, email)
    print("val")

@mongo_transactional
@transactional
def add_note(access_token, email, data, session):
    deps.validate_user_token(access_token, email)
    print("val")

@mongo_transactional
@transactional
def edit_note(access_token, email, data, session):
    deps.validate_user_token(access_token, email)
    print("val")

@mongo_transactional
@transactional
def delete_note(access_token, email, data, session):
    deps.validate_user_token(access_token, email)
    print("val")