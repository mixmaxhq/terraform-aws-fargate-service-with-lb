variable "name" {
  description = "The name of the service/app to deploy. This is longform; for example, use 'contacts-worker' instead of 'contacts'"
}

variable "environment" {
  description = "The environment this service lives in"
}

variable "service" {
  description = "The service this app serves. For example, if name is 'contacts-worker', this would be 'contacts'"
}
