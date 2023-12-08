/*** Defines all of the variables that will be stored among all of the components in the App ***/
import { writable } from 'svelte/store'

export const authToken = writable(null) // Authentication token collected from flask fetch during log-in process

export const username = writable(null) // Username that was collected during auth process.
export const userSkillLevel = writable(null) // Username that was collected during auth process.

