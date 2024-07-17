// third-party
import { Express, Router } from "express";

// service
import { getUserHandler } from "./get-user-handler";

// pkg
// import { User } from "@pkg/users";

export type Context = {
  // usersSvc: UserGetter,
}

// interface UserGetter {
//   get(email: string): Promise<User>;
// }

export function usersRoutes(
  router: Express,
  ctx: Context,
) {
  const usersRouter = Router();
  usersRouter.get("/", getUserHandler(ctx));

  router.use("/users", usersRouter);
}
