# Use an official Node.js runtime as the base image
FROM node:18

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install application dependencies
RUN npm ci

# Copy the rest of the application code to the working directory
COPY . .

# Expose a port for the Node.js application
EXPOSE 3001

CMD ["node", "index.js"]