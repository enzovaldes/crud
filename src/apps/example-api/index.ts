import "module-alias/register";
import express from "express";
import { usersRoutes } from "@pkg/http"

const port = process.env.PORT || 8080;
const server = express();

usersRoutes(server, {})

server.listen(port, () => {
  console.log(`http server listening on port ${port}`);
});
