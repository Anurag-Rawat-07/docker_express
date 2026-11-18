FROM node:20-alpine3.19 as base   
#taking alpine as base image


# Stage 1: Build Stuff
FROM base as builder

WORKDIR /home/build

COPY package*.json .
COPY tsconfig.json .

RUN npm install

COPY src/ src/

RUN npm run build

# Stage 2: Runner
FROM base as runner

WORKDIR /home/app

COPY --from=builder /home/build/dist dist/
COPY --from=builder /home/build/package*.json .

RUN npm install --omit=dev         
#only install express not development dependencies

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nodejs

USER nodejs           
#non-root user, doesnt have access to admin privilages


EXPOSE 8000
ENV PORT=8000

CMD [ "npm", "start" ]

#after execution of 2nd stage, the folders and files of first stage get deleted