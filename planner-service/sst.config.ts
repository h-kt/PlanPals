/// <reference path="./.sst/platform/config.d.ts" />
export default $config({
  app(input) {
    return {
      name: 'planner-service',
      providers: {
        aws: {
          profile: input.stage === 'production' ? 'pp-prod' : 'pp-dev',
        },
        mongodbatlas: '3.20.3',
      },
      removal: input?.stage === 'production' ? 'retain' : 'remove',
      home: 'aws',
    }
  },
  async run() {
    const vpc = new sst.aws.Vpc('PlanPalsAWSVPC', { bastion: true })
    const cluster = new sst.aws.Cluster('PlanPalsAWSCluster', { vpc })

    const atlasOwner = mongodbatlas.getAtlasUser({
      username: process.env.MONGODB_ATLAS_OWNER_USERNAME,
    })

    const orgId = mongodbatlas.getRolesOrgId({})

    const atlasProject = new mongodbatlas.Project('PlanPalsAtlasProject', {
      orgId: orgId.then((res) => res.orgId),
      isPerformanceAdvisorEnabled: false,
      name: 'PlanPalsAtlasProject',
      isCollectDatabaseSpecificsStatisticsEnabled: false,
      isRealtimePerformancePanelEnabled: false,
      isSchemaAdvisorEnabled: false,
      isExtendedStorageSizesEnabled: false,
      isDataExplorerEnabled: false,
      projectOwnerId: atlasOwner.then((res) => res.userId!),
      withDefaultAlertsSettings: false,
    })

    const atlasClusterName = 'PlanPalsAtlasCluster'

    const atlasCluster = new mongodbatlas.Cluster(atlasClusterName, {
      projectId: atlasProject.id.apply((id) => id),
      name: atlasClusterName,
      providerName: 'TENANT',
      backingProviderName: 'AWS',
      providerRegionName: 'US_EAST_1',
      providerInstanceSizeName: 'M0',
    })

    const atlasUserName: string = 'PLACE_HOLDER_ACCESS_USERNAME'
    const atlasPassword: string = 'PLACE_HOLDER_ACCESS_PASSWORD'

    const atlasUser = new mongodbatlas.DatabaseUser('PlanPalsAtlasUser', {
      username: atlasUserName,
      password: atlasPassword,
      projectId: atlasProject.id.apply((id) => id),
      authDatabaseName: 'admin',
      roles: [
        {
          roleName: 'readWrite',
          databaseName: 'planner',
        },
        {
          roleName: 'readAnyDatabase',
          databaseName: 'admin',
        },
      ],
      scopes: [
        {
          name: atlasCluster.name.apply((name) => name),
          type: 'CLUSTER',
        },
      ],
    })

    const atlasAllowAll = new mongodbatlas.ProjectIpAccessList(
      'PlanPalsAllowAll',
      {
        projectId: atlasProject.id.apply((id) => id),
        ipAddress: '0.0.0.0',
        comment: 'Allowing all IPs',
      },
    )

    const connectionString = (uri: string) =>
      `mongodb+srv://${atlasUserName}:${atlasPassword}@${uri}/?retryWrites=true&w=majority&appName=${atlasClusterName}`
    const stdSrv = atlasCluster.connectionStrings[0].standardSrv.apply(
      (srv) => {
        return connectionString(srv.replaceAll('mongodb+srv://', ''))
      },
    )

    cluster.addService('PlanPalsService', {
      link: [atlasCluster],
      loadBalancer: {
        ports: [{ listen: '80/http', forward: '8080/http' }],
      },
      environment: {
        DATABASE_CONNECTIONSTRING: stdSrv,
      },
      dev: {
        command: 'npm i && npm run start',
      },
    })
  },
})