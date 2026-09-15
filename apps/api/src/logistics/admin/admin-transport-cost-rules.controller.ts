import { Body, Controller, Get, Param, ParseUUIDPipe, Patch, Post } from '@nestjs/common';
import { Roles } from '../../auth/decorators/roles.decorator';
import { UserRole } from '../../users/entities/user-role.enum';
import { TransportCostRulesService } from '../transport-cost-rules.service';
import { CreateTransportCostRuleDto } from '../dto/create-transport-cost-rule.dto';
import { UpdateTransportCostRuleDto } from '../dto/update-transport-cost-rule.dto';

@Controller('admin/transport-cost-rules')
@Roles(UserRole.ADMIN)
export class AdminTransportCostRulesController {
  constructor(private readonly rulesService: TransportCostRulesService) {}

  @Get()
  findAll() {
    return this.rulesService.findAllForAdmin();
  }

  @Post()
  create(@Body() dto: CreateTransportCostRuleDto) {
    return this.rulesService.create(dto);
  }

  @Patch(':id')
  update(@Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateTransportCostRuleDto) {
    return this.rulesService.update(id, dto);
  }
}
