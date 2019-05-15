data "aws_caller_identity" "current" {}

variable "api_name" {}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "${var.api_name}"
}

resource "aws_api_gateway_resource" "resource" {
  path_part = "{proxy+}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "response-200" {
  depends_on  = ["aws_api_gateway_method.method"]
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.api.id}"
  resource_id             = "${aws_api_gateway_resource.resource.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:027378352884:function:${var.lambda_func_name}/invocations"
}

resource "aws_api_gateway_integration_response" "integration-response" {
  depends_on  = ["aws_api_gateway_integration.integration"]
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.resource.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"

  status_code = "${aws_api_gateway_method_response.response-200.status_code}"

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  
  
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:us-east-1:027378352884:function:${var.lambda_func_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}


resource "aws_api_gateway_deployment" "dev" {
  depends_on  = ["aws_api_gateway_integration.integration"]
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name  = "dev"

  variables = {
    
    "deployed_at" = "${timestamp()}"
  }
}



output "invoke_urls_dev" {
  value = "${aws_api_gateway_deployment.dev.invoke_url}"
}

