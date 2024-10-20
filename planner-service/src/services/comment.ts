import { NextFunction, Request, Response } from 'express'
import { CommentModel, CommentsModel } from '../models/Comment'
import { Types } from 'mongoose'
import { RecordNotFoundException } from '../exceptions/RecordNotFoundException'
import { StatusCodes } from 'http-status-codes'

/**
 * Retrieves the comments document for the given object id and type.
 * If the comments document does not exist, this endpoint will create a new comments document
 * with an empty array of comments.
 *
 * @param req - The incoming request from the client.
 * @param res - The response to the client.
 * @param next - The next function in the middleware chain.
 *
 * @throws {RecordNotFoundException} If the object does not exist.
 */
export async function findOrCreateCommentsDocument(
  req: Request,
  res: Response,
  next: NextFunction,
) {
  if (req.body.err) {
    next(req.body.err)
  }
  const { type, objectId } = req.body.out
  let commentsDocument = await CommentsModel.findOne({
    objectId: { id: objectId, collection: type },
  })
  if (!commentsDocument) {
    commentsDocument = await CommentsModel.create({
      objectId: { id: objectId, collection: type },
      comments: [],
    })
  }
  req.body.out = { ...req.body.out, commentsDocument }
  next()
}

/**
 * Creates a new comment document in the database.
 *
 * @param req - The incoming request from the client.
 * @param res - The response to the client.
 * @param next - The next function in the middleware chain.
 *
 * @throws {RecordNotFoundException} If the comments document does not exist.
 */
const createCommentDocument = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  if (req.body.err) {
    next(req.body.err)
  }
  const { createdBy, title, content, commentsDocument } = req.body.out
  const commentDocument = await CommentModel.create({
    createdBy,
    title,
    content,
  })

  if (!commentsDocument.comments.includes(commentDocument._id)) {
    commentsDocument.comments.push(commentDocument._id)
  }
  await commentsDocument.save()

  req.body.result = commentDocument
  req.body.status = StatusCodes.CREATED
  next()
}

/**
 * Deletes a comment document from the database.
 *
 * @param req - The incoming request from the client.
 * @param res - The response to the client.
 * @param next - The next function in the middleware chain.
 *
 * @throws {RecordNotFoundException} If the comments document does not exist.
 * @throws {RecordNotFoundException} If the comment document does not exist.
 * @throws {RecordNotFoundException} If the user does not own the comment.
 */
const removeCommentDocument = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  if (req.body.err) {
    next(req.body.err)
  }
  const { commentId, userId, commentsDocument } = req.body.out

  if (!commentsDocument.comments.includes(commentId)) {
    req.body.err = new RecordNotFoundException({
      recordType: 'comment',
      recordId: commentId,
    })
    next(req.body.err)
  }

  const targetComment = await CommentModel.findOne({ _id: commentId })

  if (!targetComment) {
    req.body.err = new RecordNotFoundException({
      recordType: 'comment',
      recordId: commentId,
    })
    next(req.body.err)
  }
  if (!targetComment?.createdBy.equals(userId)) {
    req.body.err = new RecordNotFoundException({
      recordType: 'comment',
      recordId: commentId,
    })
    next(req.body.err)
  }

  commentsDocument.comments = commentsDocument.comments.filter(
    (comment: Types.ObjectId) => !comment.equals(commentId),
  )
  await commentsDocument.save()

  req.body.result = await CommentModel.findByIdAndDelete(commentId)
  req.body.status = StatusCodes.OK
  next()
}

/**
 * Retrieves the comments for an object in the planner with the given objectId and type.
 *
 * If the comments document does not exist, this endpoint will return a 404 error.
 *
 * @param req - The incoming request from the client.
 * @param res - The response to the client.
 * @param next - The next function in the middleware chain.
 *
 * @returns {Promise<void>}
 *
 * @throws {RecordNotFoundException} If the comments document does not exist.
 */
const getCommentsByObjectId = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  if (req.body.err) {
    next(req.body.err)
  }
  const { commentsDocument } = req.body.out
  const comments = commentsDocument.comments.map((comment: Types.ObjectId) =>
    CommentModel.findById(comment),
  )
  if (!comments || comments.length === 0) {
    req.body.err = new RecordNotFoundException({
      recordType: 'comments',
      recordId: commentsDocument._id,
    })
    next(req.body.err)
  }
  req.body.result = comments
  req.body.status = StatusCodes.OK
  next()
}

/**
 * Retrieves a single comment document by its ID.
 *
 * @param req - The incoming request from the client.
 * @param res - The response to the client.
 * @param next - The next function in the middleware chain.
 *
 * @throws {RecordNotFoundException} If the comment document does not exist.
 */
const getCommentById = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  if (req.body.err) {
    next(req.body.err)
  }
  const { commentId } = req.body.out
  const comment = await CommentModel.findById(commentId)
  if (!comment) {
    req.body.err = new RecordNotFoundException({
      recordType: 'comment',
      recordId: commentId,
    })
    next(req.body.err)
  }
  req.body.result = comment
  req.body.status = StatusCodes.OK
  next()
}

const CommentService = {
  findOrCreateCommentsDocument,
  createCommentDocument,
  removeCommentDocument,
  getCommentsByObjectId,
  getCommentById,
}

export default CommentService
