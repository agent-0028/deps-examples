# init-terraform-state

This will create the S3 bucket that the rest of this repo will use to store state.

Since it makes my head hurt to store state for this bucket in that same bucket, this uses local state.

So...whenever you run this from a new machine, you will need to import the state.

### Steps for first run

Use this if you have just used this template repo and you are creating a bucket for Terraform state the first time.

In the file `bucket-for-state.tf`, change the `bucket` attribute from "example-bucket-for-state" to whatever you want to call the bucket in your AWS environment.

You can find out if the bucket name you want to use is in use by running:

```
aws s3api head-bucket --bucket $YOUR_BUCKET_NAME_HERE
```

If you get a 404, the name is probably available.

If you get almost anything else, the most likely being 403, it is probably in use.

Create a key and a secret following the [AWS instructions here](https://docs.aws.amazon.com/sdkref/latest/guide/feature-static-credentials.html).

You will need a key ID and secret to set up GitHub Actions later.

Check if you can at least read from your account by running:

```
aws s3api list-buckets
```

By default, OpenTofu (or Terraform) will use your AWS credentials you have configured for using the `aws` command line client. So, if that worked, you should be able to use `tofu`.

Initialize the new backend:

```
tofu init
```

Check the plan:

```
tofu plan
```

If everything looks reasonable:

```
tofu apply
```

### Steps to import

Use this if you have previously created a bucket for state and want to get it under Terraform control with **local** state on a new workstation.

* Create import block like this:
```
import {
  to = aws_s3_bucket.example-bucket-for-state
  id = "example-bucket-for-state"
}
```
* Make sure you DO NOT declare the resource anywhere you are importing
* Run this:
```
tofu plan  -generate-config-out=generated_resources.tf
```
* Copy the output and put it in the "right place" and then comment out the file
* Run again, and look the output
```
tofu plan
```
* If the output looks clean (no changes, or safe changes)
* Run this and all that will happen is the resource will be added to state
```
tofu apply
```
