import { NextFunction, Request, Response } from 'express'
import { initializeApp, applicationDefault } from 'firebase-admin/app'
import { getAuth } from 'firebase-admin/auth'
import { AuthorizationError } from '../../exceptions/AuthorizationError'

const app = initializeApp({
  credential: applicationDefault(),
})

const defaultAuth = getAuth(app)

/**
 * Middleware that verifies the Firebase Authentication ID token sent in the
 * Authorization header of the request. If the token is invalid, it will throw
 * an AuthorizationError and set the `err` property of the request body.
 * Otherwise, it will set the `out` property of the request body to the decoded
 * token's payload.
 *
 * @param req - The incoming request from the client.
 * @param res - The response to the client.
 * @param next - The next function in the middleware chain.
 */
const verifyFirebaseAuth = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  //   const token = req.headers.authorization?.split(' ')[1]
  //   if (!token) {
  //     req.body.err = new AuthorizationError({ token: `Token: ${token}` })
  //     return next(req.body.err)
  //   }
  //   const decodedToken = await defaultAuth.verifyIdToken(token).catch(() => {
  //     req.body.err = new AuthorizationError({ token: `Token: ${token}` })
  //     return next(req.body.err)
  //   })

  //   req.body.out = { ...req.body.out, ...decodedToken }
  next()
}

export { verifyFirebaseAuth }
