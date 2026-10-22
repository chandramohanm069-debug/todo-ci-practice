# A box that already has Node installed. 18-alpine = Node 18 on a
# small, lightweight Linux.
FROM node:18-alpine

# Everything below runs as if you'd cd'd into /app inside the box.
WORKDIR /app

# Copy just package.json first. Docker skips re-running npm install
# on the next build if this file hasn't changed, so rebuilds are faster.
COPY package*.json ./

RUN npm install

# Now copy the rest of the code in.
COPY . .

# Documentation for humans - docker-compose / -p does the actual opening.
EXPOSE 5000

CMD ["npm", "start"]
