// third-party
import { Request, Response } from "express";

// internal
import { User } from "@pkg/users";

// service
import { Context } from "./routes";

export const getUserHandler = (ctx: Context) => {
  return async (_: Request, res: Response) => {

    const user: User = {
      email: "enzo@gmail.com"
    }

    console.log("ctx", ctx);

    return res.status(200).send({
      user,
    });
  }
}
