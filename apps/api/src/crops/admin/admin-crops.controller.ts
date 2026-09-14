import { Body, Controller, Get, Param, ParseUUIDPipe, Patch, Post } from '@nestjs/common';
import { Roles } from '../../auth/decorators/roles.decorator';
import { UserRole } from '../../users/entities/user-role.enum';
import { CropsService } from '../crops.service';
import { CreateCropDto } from '../dto/create-crop.dto';
import { UpdateCropDto } from '../dto/update-crop.dto';

// Full CRUD-minus-delete over the crop catalog. No DELETE: a crop
// referenced by an existing FarmCropRecord is protected by an FK
// (ON DELETE RESTRICT) anyway, so the real "remove a crop" operation is
// deactivating it (isActive: false via PATCH), not deleting the row —
// that preserves the history of any record that already points at it.
@Controller('admin/crops')
@Roles(UserRole.ADMIN)
export class AdminCropsController {
  constructor(private readonly cropsService: CropsService) {}

  @Get()
  findAll() {
    return this.cropsService.findAllForAdmin();
  }

  @Post()
  create(@Body() dto: CreateCropDto) {
    return this.cropsService.create(dto);
  }

  @Patch(':id')
  update(@Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateCropDto) {
    return this.cropsService.update(id, dto);
  }
}
