from flask import Flask
from flask_restful import Api, Resource, reqparse, abort, fields, marshal_with
from flask_sqlalchemy import SQLAlchemy


app = Flask(__name__)
api = Api(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
db = SQLAlchemy(app)


class PodcastModel(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    views = db.Column(db.Integer, nullable=False)
    likes = db.Column(db.Integer, nullable=False)

    def __repr__(self):
        return f"Podcast(name = {self.name}, views = {self.views}, likes = {self.likes})"


podcast_put_arg = reqparse.RequestParser()
podcast_put_arg.add_argument("name", type=str, help="Name of the podcast", required=True)
podcast_put_arg.add_argument("views", type=int, help="Views of the podcast", required=True)
podcast_put_arg.add_argument("likes", type=int, help="Likes of the podcast", required=True)

resource_fields = {
    'id': fields.Integer,
    'name': fields.String,
    'views': fields.Integer,
    'likes': fields.Integer
}


class Podcast(Resource):
    @marshal_with(resource_fields)
    def get(self, podcast_id):
        result = PodcastModel.query.filter_by(id=podcast_id).first()
        return result

    @marshal_with(resource_fields)
    def put(self, podcast_id):
        args = podcast_put_arg.parse_args()
        podcast = PodcastModel(id=podcast_id, name=args['name'], views=args['views'], likes=args['likes'])
        db.session.add(podcast)
        db.session.commit()
        return podcast, 201


api.add_resource(Podcast, "/podcast/<int:podcast_id>")

if __name__ == "__main__":
    app.run(debug=True)
