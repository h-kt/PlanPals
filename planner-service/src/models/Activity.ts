import { z } from 'zod'
import { ObjectIdSchema } from './Planner'
import mongoose, { Schema } from 'mongoose'
import { DestinationModel } from './Destination'

const ActivityMongoSchema = new Schema<Activity>(
  {
    createdBy: {
      type: Schema.Types.ObjectId,
      required: true,
      ref: 'User',
    },
    startDate: {
      type: String,
      required: true,
    },

    name: {
      type: String,
      required: true,
    },

    location : {
      type: String,
    },

    duration: {
      type: Number,
      required: true,
    },

    done: {
      type: Boolean,
      required: true,
    },

    destinationId: {
      type: Schema.Types.ObjectId,
      ref: 'Destination',
      required: true,
    },
  },
  { _id: true, timestamps: true },
)

ActivityMongoSchema.pre('findOneAndDelete', async function (next) {
  try {
    const query = this.getQuery()
    const activity = await this.model.findOne(query)

    if (activity) {
      await DestinationModel.findByIdAndUpdate(
        { _id: activity.destinationId },
        { $pull: { activities: activity._id } },
      )
    }

    next()
  } catch (error) {
    next(error as Error)
  }
})

export const ActivitySchema = z.object({
  _id: ObjectIdSchema,

  createdAt: z.string().datetime(),
  createdBy: ObjectIdSchema,
  updatedAt: z.string().datetime(),

  startDate: z.string().datetime(),

  name: z.string(),
  location: z.string().optional(),
  duration: z.number().optional(),
  done: z.boolean(),

  destinationId: ObjectIdSchema,
})

export const ActivityModel = mongoose.model<Activity>(
  'Activity',
  ActivityMongoSchema,
)
export type Activity = z.infer<typeof ActivitySchema>
