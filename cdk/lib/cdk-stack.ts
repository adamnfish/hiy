import cdk = require('@aws-cdk/core');
import apigateway = require('@aws-cdk/aws-apigateway');
import lambda = require('@aws-cdk/aws-lambda');
import ssm = require('@aws-cdk/aws-ssm');
import s3 = require('@aws-cdk/aws-s3');
import cloudfront = require('@aws-cdk/aws-cloudfront');
import acm = require('@aws-cdk/aws-certificatemanager');
import route53 = require('@aws-cdk/aws-route53');
import route53Targets = require('@aws-cdk/aws-route53-targets');
import iam = require('@aws-cdk/aws-iam');
import * as path from "path";
import {HostedZone} from "@aws-cdk/aws-route53";


export class HiyApp extends cdk.Stack {

  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const apiTimeout = cdk.Duration.seconds(10);

    const nreToken = ssm.StringParameter
        .valueForStringParameter(this, '/adamnfish/hiy/nre-token', 1);
    const subdomain = ssm.StringParameter
        .valueForStringParameter(this, '/adamnfish/hiy/subdomain', 1);
    const domain = ssm.StringParameter
        .valueForStringParameter(this, '/adamnfish/hiy/domain', 1);
    const hostedZoneId = ssm.StringParameter
        .valueForStringParameter(this, '/adamnfish/hiy/hosted-zone-id', 1);
    const acmCertArn = ssm.StringParameter
        .valueForStringParameter(this, '/adamnfish/hiy/acm-arn', 1);

    const fn = new lambda.Function(this, "hiy-api-lambda", {
      runtime: lambda.Runtime.JAVA_8,
      timeout: apiTimeout,
      memorySize: 1024,
      handler: 'com.adamnfish.hiy.Lambda::handleRequest',
      code: lambda.Code.fromAsset(path.join(__dirname, '../../api/target/scala-2.13/hiy-api.jar')),
      environment: {
        NRE_TOKEN: nreToken
      }
    });
    const ag = new apigateway.LambdaRestApi(this, "hiy-gateway", {
      handler: fn
    });

    // See AWS-CDK Issue: https://github.com/aws/aws-cdk/issues/941
    // via
    // https://medium.com/@david.sandor/deploy-a-spa-website-to-aws-s3-with-cloudfront-cdn-in-40-lines-of-typescript-using-aws-cdk-ff800b6c1bb8
    // https://github.com/dsandor/cdk-static-website
    const cloudFrontOia = new cloudfront.CfnCloudFrontOriginAccessIdentity(this, 'OIA', {
      cloudFrontOriginAccessIdentityConfig: {
        comment: `OIA for hiy app.`
      }
    });

    const webrootBucket = new s3.Bucket(this, 'hiy-public');
    const acmCert = acm.Certificate.fromCertificateArn(this, 'hiy-cert', acmCertArn);
    const distribution = new cloudfront.CloudFrontWebDistribution(this, 'hiy-distribution', {
      viewerCertificate: cloudfront.ViewerCertificate.fromAcmCertificate(acmCert, {
        aliases: [ `${subdomain}.${domain}` ]
      }),
      originConfigs: [
        // static site in S3
        {
          s3OriginSource: {
            s3BucketSource: webrootBucket,
            originAccessIdentityId: cloudFrontOia.ref
          },
          behaviors : [
            { isDefaultBehavior: true }
          ]
        },
        // serve Lambda-backed API under /api/*
        {
          customOriginSource: {
            domainName: `${ag.restApiId}.execute-api.eu-west-1.amazonaws.com`,
            originProtocolPolicy: cloudfront.OriginProtocolPolicy.HTTPS_ONLY,
            originReadTimeout: apiTimeout
          },
          originPath: `/${ag.deploymentStage.stageName}`,
          behaviors : [
            {
              defaultTtl: cdk.Duration.seconds(60),
              pathPattern: "/api/*",
              forwardedValues: {
                queryString: true
              }
            }
          ]
        }
      ]
    });
    const policyStatement = new iam.PolicyStatement();
    policyStatement.addActions('s3:GetBucket*');
    policyStatement.addActions('s3:GetObject*');
    policyStatement.addActions('s3:List*');
    policyStatement.addResources(webrootBucket.bucketArn);
    policyStatement.addResources(`${webrootBucket.bucketArn}/*`);
    policyStatement.addCanonicalUserPrincipal(cloudFrontOia.attrS3CanonicalUserId);
    webrootBucket.addToResourcePolicy(policyStatement);

    const hostedZone = HostedZone.fromHostedZoneAttributes(this, 'hiy-dns-hostedzone', {
      hostedZoneId: hostedZoneId,
      zoneName: domain
    });
    const aRecord = new route53.ARecord(this, 'hiy-dns', {
      target: route53.RecordTarget.fromAlias(new route53Targets.CloudFrontTarget(distribution)),
      zone: hostedZone,
      recordName: subdomain
    });

    new cdk.CfnOutput(this, "webroot-bucket", {
      value: webrootBucket.bucketName
    });
    new cdk.CfnOutput(this, "domain-name", {
      value: aRecord.domainName
    });
    new cdk.CfnOutput(this, "distribution-id", {
      value: distribution.distributionId
    });
  }
}
