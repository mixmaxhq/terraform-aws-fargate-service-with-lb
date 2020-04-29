// This name is defined in the Jenkins management console, and pulled from a github repository under
// our mixmaxhq organization by the same name. Specify a specific tag/revision by appending it along
// with an '@' symbol to the string literal.
@Library('scm-service-library') _

terraformModulePipeline {
  // The following contains the directories of each example to lint & validate
  exampleDirs = ["examples/simple", "examples/one_service_two_lbs", "examples/public_only_to_github"]
}
