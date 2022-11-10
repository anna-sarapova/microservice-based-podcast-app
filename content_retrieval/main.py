import requests
from flask import Flask
from flask_restful import Api, Resource, reqparse, abort, fields, marshal_with
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
api = Api(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///podcast.db'
db = SQLAlchemy(app)


# The database model
class PodcastModel(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String, nullable=False)
    description = db.Column(db.String, nullable=False)
    podcast_file = db.Column(db.String, nullable=False)

    def __repr__(self):
        return f"Podcast(name = {self.name}, description = {self.description}, podcast_file = {self.podcast_file})"


# Creates the database following the above model
db.create_all()

podcast_put_arg = reqparse.RequestParser()
podcast_put_arg.add_argument("name", type=str, help="Missing name of the podcast", required=True)
podcast_put_arg.add_argument("description", type=str, help="Missing description of the podcast", required=True)
podcast_put_arg.add_argument("podcast_file", type=str, help="The podcast", required=True)

# decorator for extracting data from the database
resource_fields = {
    'id': fields.Integer,
    'name': fields.String,
    'description': fields.String,
    'podcast_file': fields.String
}


class PodcastList(Resource):
    def get(self):
        response = requests.get('http://127.0.0.1:9000/cache_podcasts')
        print("response: ", response.json())
        podcast_list = []
        if response.json() is None:
            # for data in PodcastModel.query.all():
            #     row_as_dict = data._asdict()
            data = [row.__dict__ for row in PodcastModel.query.all()]
            print("data: ", data)
            for element in data:
                new_element = {key: val for key,
                               val in element.items() if key != '_sa_instance_state'}
                podcast_list.append(new_element)
            requests.post('http://127.0.0.1:9000/cache_podcasts', json=podcast_list)
            return podcast_list
        else:
            print("Response: ", response.json())
            return response.json()


# def object_as_dict(db_data):
#     dictionary = {}
#     for column in db_data.__table__.column:
#

class Podcast(Resource):
    @marshal_with(resource_fields)
    def get(self, podcast_id):
        response = requests.get('http://127.0.0.1:9000/cache_podcast/' + str(podcast_id))
        print("Response after Get by id: ", response)
        if response is not None:
            return response
        else:
            result = PodcastModel.query.filter_by(id=podcast_id).first()
            requests.put('http://127.0.0.1:9000/cache_podcast/' + str(podcast_id), result)
            if not result:
                abort(409, message="No podcast with that id..")
            return result

    @marshal_with(resource_fields)  # serialise the response
    def put(self, podcast_id):
        args = podcast_put_arg.parse_args()
        result = PodcastModel.query.filter_by(id=podcast_id).first()
        if result:
            abort(409, message="Podcast id taken..")
        podcast = PodcastModel(id=podcast_id, name=args['name'], description=args['description'], podcast_file=args['podcast_file'])
        db.session.add(podcast)  # adding temporarily the podcast to the DB session
        db.session.commit()      # adding permanently the podcast to the DB
        return podcast, 201


api.add_resource(PodcastList, "/podcasts")
api.add_resource(Podcast, "/podcast/<int:podcast_id>")

if __name__ == "__main__":
    app.run(port=5000, debug=True)
    personal_data = {"name": "content_retrieval", "address": "http://127.0.0.1", "port": 5000, "status": "active"}
    requests.post('http://127.0.0.1:8008/register_me', json=personal_data)
    print("Register request was sent")
