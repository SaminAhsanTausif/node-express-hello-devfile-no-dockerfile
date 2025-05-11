# Use a specific Node.js version as the base image
FROM node:16-alpine

# Set environment variables for development and production environments
ARG ENV=development
ENV NODE_ENV $ENV

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code into the container
COPY . .

# Expose the port that your app will run on
EXPOSE 3000

# Set the default command to run your app
CMD ["npm", "start"]
