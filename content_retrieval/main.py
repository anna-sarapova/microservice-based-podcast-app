from flask import Flask, request
from flask_restful import Api, Resource, reqparse, abort, fields, marshal_with
from flask_sqlalchemy import SQLAlchemy
import requests
from sqlalchemy import select
from sqlalchemy.orm import load_only, mapper
from sqlalchemy.orm import defer, undefer

app = Flask(__name__)
api = Api(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///podcast.db'
db = SQLAlchemy(app)


# The database model
class PodcastModel(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String, nullable=False)
    description = db.Column(db.String, nullable=False)
    podcast = db.Column(db.String, nullable=False)

    def __repr__(self):
        return f"Podcast(name = {self.name}, description = {self.description}, podcast = {self.podcast})"


# Creates the database following the above model
# db.create_all()


podcast_put_arg = reqparse.RequestParser()
podcast_put_arg.add_argument("name", type=str, help="Missing name of the podcast", required=True)
podcast_put_arg.add_argument("description", type=str, help="Missing description of the podcast", required=True)
podcast_put_arg.add_argument("podcast", type=str, help="The podcast", required=True)

# decorator for extracting data from the database
resource_fields = {
    'id': fields.Integer,
    'name': fields.String,
    'description': fields.String,
    'podcast': fields.String
}


class PodcastList(Resource):
    @marshal_with(resource_fields)
    def get(self):
        # args = podcast_put_arg.parse_args()
        podcast_list = PodcastModel.query.all()
        # podcast_list = PodcastModel.query.filter_by(name=args["name"]).all()
        return podcast_list


class Podcast(Resource):
    @marshal_with(resource_fields)
    def get(self, podcast_id):
        result = PodcastModel.query.filter_by(id=podcast_id).first()
        if not result:
            abort(409, message="No podcast with that id..")
        return result

    @marshal_with(resource_fields)  # serialise the response
    def put(self, podcast_id):
        args = podcast_put_arg.parse_args()
        result = PodcastModel.query.filter_by(id=podcast_id).first()
        if result:
            abort(409, message="Podcast id taken..")
        podcast = PodcastModel(id=podcast_id, name=args['name'], description=args['description'], podcast=args['podcast'])
        db.session.add(podcast)  # adding temporarily the podcast to the DB session
        db.session.commit()      # adding permanently the podcast to the DB
        return podcast, 201


api.add_resource(PodcastList, "/podcasts")
api.add_resource(Podcast, "/podcast/<int:podcast_id>")

if __name__ == "__main__":
    app.run(debug=True)
