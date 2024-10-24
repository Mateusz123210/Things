from app.mongo_database import collection_things
from fastapi import HTTPException
from app.decorators.mongo_database import mongo_transactional
from app.decorators.database import transactional
from app import deps
from app.schemas import *

@mongo_transactional
@transactional
def get_user_categories(access_token, email, session):
    deps.validate_user_token(access_token, email)

    user = collection_things.find_one({"email": email}, session=session)

    if user:
        
        user_categories = user["categories"]

        return user_categories
    
    else:
        return {}

@mongo_transactional
@transactional
def add_category(access_token, email, data: CategoryAdd, session):

    deps.validate_user_token(access_token, email)

    if len(data.name) == 0:
        raise HTTPException(status_code=400, detail="Category field is empty!")

    user = collection_things.find_one({"email": email}, session=session)

    if user:
        
        user_categories = user["categories"]

        for i in range (len(user_categories)):
            if data.name == user_categories[i][0]:
                raise HTTPException(status_code=400, detail="You already have category with this name!")
        
        user_categories.append([data.name, data.photo])

        filter = { '_id': user["_id"] }
        new_values = { "$set": { 'categories': user_categories } }

        collection_things.update_one(filter, new_values, session=session)
    
    else:

        insert_data = {"email": email, "categories": [[data.name, data.photo]], "products": [], "notes": []}
        collection_things.insert_one(insert_data)

    return {}

@mongo_transactional
@transactional
def edit_category(access_token, email, data, session):

    deps.validate_user_token(access_token, email)
    
    if len(data.old_name) == 0:
        raise HTTPException(status_code=400, detail="Old category name is invalid!")
    
    if len(data.name) == 0:
        raise HTTPException(status_code=400, detail="Category field is empty!")

    user = collection_things.find_one({"email": email}, session=session)

    if user:
        
        user_categories = user["categories"]

        category_index = None

        for i in range (len(user_categories)):
            if data.old_name == user_categories[i][0]:
                category_index = i
                
        if category_index is None:
            raise HTTPException(status_code=400, detail="Category does not exist!")
        
        if data.old_name == data.name:
            if user_categories[category_index][1] != data.photo:
                user_categories[category_index][1] = data.photo

                user_products = user["products"]
                for i in range (len(user_products)):
                    if data.old_name == user_products[i][1]:
                        user_products[i][1] = data.name
                
                filter = { '_id': user["_id"] }
                new_values = { "$set": { 'products': user_products } }
                
                collection_things.update_one(filter, new_values, session=session)

                new_values = { "$set": { 'categories': user_categories } }
                
                collection_things.update_one(filter, new_values, session=session)
            
            else:
                raise HTTPException(status_code=400, detail="You have not changed anything!")
        else:

            for i in range (len(user_categories)):
                if data.name == user_categories[i][0]:
                    raise HTTPException(status_code=400, detail="New category name already exists!")
            
            user_categories[category_index] = [data.name, data.photo]

            user_products = user["products"]
            for i in range (len(user_products)):
                if data.old_name == user_products[i][1]:
                    user_products[i][1] = data.name
            
            filter = { '_id': user["_id"] }
            
            new_values = { "$set": { 'products': user_products } }
                
            collection_things.update_one(filter, new_values, session=session)
            
            new_values = { "$set": { 'categories': user_categories } }

            collection_things.update_one(filter, new_values, session=session)
    
    else:

        raise HTTPException(status_code=400, detail="Category does not exist!")

    return {}

@mongo_transactional
@transactional
def delete_category(access_token, email, data, session):

    deps.validate_user_token(access_token, email)
    
    if len(data.name) == 0:
        raise HTTPException(status_code=400, detail="Category name not given!")
    
    user = collection_things.find_one({"email": email}, session=session)

    if user:

        user_categories = user["categories"]

        category_index = None

        for i in range (len(user_categories)):
            if data.name == user_categories[i][0]:
                category_index = i
                
        if category_index is None:
            raise HTTPException(status_code=400, detail="Category does not exist!")
        
        del user_categories[category_index]

        filter = { '_id': user["_id"] }
        new_values = { "$set": { 'categories': user_categories } }

        collection_things.update_one(filter, new_values, session=session)

        user_products = user["products"]
        for i in reversed (range (len (user_products))):
            if data.name == user_products[i][1]:
                del user_products[i]
    
        filter = { '_id': user["_id"] }
            
        new_values = { "$set": { 'products': user_products } }
            
        collection_things.update_one(filter, new_values, session=session)

    else:
        raise HTTPException(status_code=400, detail="Category does not exist!")
    
    return {}

@mongo_transactional
@transactional
def get_category_products(access_token, email, data, session):

    deps.validate_user_token(access_token, email)
    
    if len(data.name) == 0:
        raise HTTPException(status_code=400, detail="Category name not given!")

    user = collection_things.find_one({"email": email}, session=session)

    if user:
        
        user_categories = user["categories"]

        category_index = None

        for i in range (len(user_categories)):
            if data.name == user_categories[i][0]:
                category_index = i
                
        if category_index is None:
            raise HTTPException(status_code=400, detail="Category does not exist!")
        
        user_products = user["products"]

        for i in reversed (range (len (user_products))):
            if data.name != user_products[i][1]:
                del user_products[i]
        
        return user_products
        
    else:

        raise HTTPException(status_code=400, detail="Category does not exist!")

@mongo_transactional
@transactional
def get_product(access_token, email, data, session):

    deps.validate_user_token(access_token, email)

    if len(data.name) == 0:
            raise HTTPException(status_code=400, detail="Product name not given!")
    
    if len(data.category_name) == 0:
            raise HTTPException(status_code=400, detail="Category name not given!")
    
    user = collection_things.find_one({"email": email}, session=session)

    if user:
        
        user_categories = user["categories"]

        category_index = None

        for i in range (len(user_categories)):
            if data.category_name == user_categories[i][0]:
                category_index = i
                
        if category_index is None:
            raise HTTPException(status_code=400, detail="Category does not exist!")
        
        user_products = user["products"]

        for i in range (len (user_products)):
            if data.name == user_products[i][0] and data.category_name == user_products[i][1]:
                return user_products[i]
               
    else:

        raise HTTPException(status_code=400, detail="Product does not exist!")
    
    return {}
    
@mongo_transactional
@transactional
def add_product(access_token, email, data, session):
    deps.validate_user_token(access_token, email)

    if len(data.name) == 0:
        raise HTTPException(status_code=400, detail="Product name not given!")
    
    if len(data.category_name) == 0:
        raise HTTPException(status_code=400, detail="Category name not given!")
    
    if len(data.quantity) == 0:
        raise HTTPException(status_code=400, detail="Product quantity not given!")

    user = collection_things.find_one({"email": email}, session=session)

    if user:
        
        user_categories = user["categories"]

        category_index = None

        for i in range (len(user_categories)):
            if data.category_name == user_categories[i][0]:
                category_index = i
                
        if category_index is None:

            raise HTTPException(status_code=400, detail="Category does not exist!")
        
        user_products = user["products"]
        for i in range (len (user_products)):
            if data.name == user_products[i][0] and data.category_name == user_products[i][1]:
                raise HTTPException(status_code=400, detail="Product with this name already exists!")

        user_products.append([data.name, data.category_name, data.quantity, data.photo, data.audio, data.video])

        filter = { '_id': user["_id"] }
            
        new_values = { "$set": { 'products': user_products } }
            
        collection_things.update_one(filter, new_values, session=session)

    else: 

        raise HTTPException(status_code=400, detail="Category does not exist!")
    
    return {}

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