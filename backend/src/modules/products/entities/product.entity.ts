import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { Category } from '../../categories/entities/category.entity';
import { ProductVariant } from './product-variant.entity';

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'category_id' })
  categoryId: string;

  @Column({ length: 200 })
  name: string;

  @Column({ unique: true, length: 200 })
  slug: string;

  @Column({ nullable: true, type: 'text' })
  description?: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  price: number;

  @Column({ name: 'image_url', nullable: true, length: 500 })
  imageUrl?: string;

  @Column({ name: 'is_available', default: true })
  isAvailable: boolean;

  @Column({ name: 'is_featured', default: false })
  isFeatured: boolean;

  @Column({ name: 'sort_order', default: 0 })
  sortOrder: number;

  @Column({ nullable: true, type: 'int' })
  calories?: number;

  @Column({ nullable: true, type: 'decimal', precision: 6, scale: 1 })
  sugar?: number;

  @Column({ nullable: true, type: 'decimal', precision: 6, scale: 1 })
  fat?: number;

  @Column({ nullable: true, type: 'decimal', precision: 6, scale: 1 })
  protein?: number;

  @Column({ nullable: true, type: 'decimal', precision: 6, scale: 1 })
  caffeine?: number;

  @Column({ nullable: true, type: 'text', array: true })
  ingredients?: string[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => Category, (category) => category.products)
  @JoinColumn({ name: 'category_id' })
  category: Category;

  @OneToMany(() => ProductVariant, (variant) => variant.product)
  variants: ProductVariant[];
}
