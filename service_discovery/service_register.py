import requests
from flask_restful import Api, Resource
from flask import Flask, request

app = Flask(__name__)
api = Api(app)

service_registry = []  # this is a list of dictionaries


class RegisterMe(Resource):
    def post(self):
        print("Data in service registry", service_registry)
        data = request.get_json(force=True)
        updated_list = update_dictionary(data)
        # health_check()
        print("Updated list from Post request ", updated_list)
        return "Successfully registered!"


class RequestedList(Resource):
    def get(self):
        print("Updated list from Get request", service_registry)
        return service_registry


def update_dictionary(discovery_data):
    print("Discovery data", discovery_data)
    if len(service_registry) > 0:
        for item in service_registry:
            if discovery_data['port'] == item['port']:
                index = service_registry.index(item)
                service_registry[index] = discovery_data
                print("Item is replaced")
                break
            else:
                continue
        else:
            service_registry.append(discovery_data)
    else:
        service_registry.append(discovery_data)
        print("Service registry", service_registry)
    return service_registry


api.add_resource(RegisterMe, "/register_me")
api.add_resource(RequestedList, "/service_registry")

if __name__ == "__main__":
    app.run(port=8008, debug=True)



