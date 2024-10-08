import { afterAll, beforeAll, describe, expect, it } from '@jest/globals'
import request from 'supertest'
import PlanPals from '../src/app'
import { StatusCodes } from 'http-status-codes'
import { UserModel } from '../src/models/User'
import { PlannerModel } from '../src/models/Planner'

describe('User API', () => {
  let app: PlanPals
  let testUserId: string
  let testUserName: string = 'Jdoe'
  let testPreferredName: string = 'John Doe'

  beforeAll(async () => {
    const mongoURI = process.env.MONGO_URL
    app = new PlanPals({ dbURI: mongoURI })
    app.startServer()
  })

  afterAll(() => {
    app.stopServer()
  })

  it('should return Created', async () => {
    const response = await request(app.app)
      .post('/user')
      .send({ userName: testUserName, preferredName: testPreferredName })
      .expect('Content-Type', /json/)
    .expect(StatusCodes.CREATED)
    
    expect(response.body.success).toBe(true)
    expect(response.body.data.userName).toBe(testUserName)
    expect(response.body.data._id).toBeDefined()
    expect(response.body.data.createdAt).toBeDefined()
    expect(response.body.data.updatedAt).toBeDefined()

    testUserId = response.body.data._id
  })

  it('should return OK', async () => {
    const response = await request(app.app)
      .get('/user/' + testUserId)
      .expect('Content-Type', /json/)
      .expect(StatusCodes.OK)

    expect(response.body.success).toBe(true)
    expect(response.body.data.userName).toBe(testUserName)
    expect(response.body.data._id).toBe(testUserId)
  })

  it('should return OK', async () => {
    testUserName = 'JDDDDoe'
    const response = await request(app.app)
      .patch('/user/' + testUserId)
      .send({ userName: testUserName })
      .expect('Content-Type', /json/)
      .expect(StatusCodes.OK)

    expect(response.body.success).toBe(true)
    expect(response.body.data.userName).toBe(testUserName)
    expect(response.body.data._id).toBe(testUserId)
  })

  it('should return Not Found', async () => {
    const response = await request(app.app)
      .get('/user/search?userName=john')
      .expect('Content-Type', /json/)
      .expect(StatusCodes.NOT_FOUND)

    expect(response.body.success).toBe(false)
  })

  it('should return OK', async () => {
    const response = await request(app.app)
      .delete('/user/' + testUserId)
      .expect('Content-Type', /json/)
      .expect(StatusCodes.OK)

    expect(response.body.success).toBe(true)
    expect(response.body.data._id).toBe(testUserId)
  })

  it('should return Bad Request', async () => {
    const response = await request(app.app)
      .get('/user/jane')
      .expect(StatusCodes.BAD_REQUEST)

      expect(response.body.success).toBe(false)
    expect(response.body.message).toBeDefined()
  })

  it('should return Not Found', async () => {
    const response = await request(app.app).get(
      '/user/6701a389fecd4f214c79183e',
    )
    .expect(StatusCodes.NOT_FOUND)

    expect(response.body.success).toBe(false)
    expect(response.body.message).toBeDefined()
  })
})
