# Clean up all contain and images that exist 
docker system prune -af

# Open ratings directory
cd ratings

# Build image and run docker of mongodb and ratings
docker build -t mongodb .
docker build -t ratings .

docker run -d --name mongodb -p 27017:27017 \
  -v $(pwd)/databases:/docker-entrypoint-initdb.d \
  -e MONGODB_ROOT_PASSWORD=CHANGEME -e MONGODB_USERNAME=ratings -e MONGODB_PASSWORD=CHANGEME \
  -e MONGODB_DATABASE=ratings bitnami/mongodb:5.0.2-debian-10-r2

docker run -d --name ratings -p 8080:8080 \
  --link mongodb:mongodb -e SERVICE_VERSION=v2 \
  -e 'MONGO_DB_URL=mongodb://mongodb:27017/ratings' \
  -e SERVICE_VERSION=v2 -e MONGO_DB_USERNAME=ratings \
  -e MONGO_DB_PASSWORD=CHANGEME ratings

#Open detail directory
cd ../sitkmutt-bookinfo-details/

#Build image and run docker of details 
docker build -t details .

docker run -d --name details -p 8081:8081 -e ENABLE_EXTERNAL_BOOK_SERVICE=true -e DO_NOT_ENCRYPT=false details

#Open review directory
cd ../sitkmutt-bookinfo-reviews/

#Build image and run docker of review
docker build -t reviews .

docker run -d --name reviews -p 8082:9080 \
  --link ratings:ratings \
  -e 'RATINGS_SERVICE=http://ratings:8080' \
  -e ENABLE_RATINGS=true reviews

#Open productpage directory
cd ../sitkmutt-bookinfo-productpage/

#Build image and run docker of productpage
docker build -t productpage .

docker run -d --name productpage -p 8083:8083 \
  --link details:details --link ratings:ratings \
  --link reviews:reviews \
  -e 'DETAILS_HOSTNAME=http://details:8081' \
  -e 'RATINGS_HOSTNAME=http://ratings:8080' \
  -e 'REVIEWS_HOSTNAME=http://reviews:9080' \
  -e FLOOD_FACTOR=0 productpage

