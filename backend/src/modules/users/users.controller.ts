import { Controller, Get, Patch, Body, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { UsersService } from './users.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { User } from './entities/user.entity';
import { UserResponseDto } from './dto/user-response.dto';

@Controller('users')
@UseGuards(AuthGuard('jwt'))
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  getProfile(@CurrentUser() user: User): UserResponseDto {
    return this.usersService.toResponse(user);
  }

  @Patch('me')
  async updateProfile(
    @CurrentUser() user: User,
    @Body() data: { fullName?: string; email?: string; avatarUrl?: string },
  ): Promise<UserResponseDto> {
    return this.usersService.updateProfile(user.id, data);
  }
}
