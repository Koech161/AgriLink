// lib/widgets/common/crop_selection_chip.dart
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class CropType {
  final String name;
  final String icon;
  final String code;
  final Color color;
  final int shelfLife;
  final String category;
  final List<String> seasons;

  const CropType({
    required this.name,
    required this.icon,
    required this.code,
    required this.color,
    required this.shelfLife,
    required this.category,
    required this.seasons,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CropType &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class CropSelectionChip extends StatefulWidget {
  final CropType crop;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final bool showDetails;
  final bool isMultiSelect;
  final double size;

  const CropSelectionChip({
    Key? key,
    required this.crop,
    required this.isSelected,
    required this.onSelected,
    this.showDetails = false,
    this.isMultiSelect = true,
    this.size = 100,
  }) : super(key: key);

  @override
  _CropSelectionChipState createState() => _CropSelectionChipState();
}

class _CropSelectionChipState extends State<CropSelectionChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onSelected(!widget.isSelected),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: widget.size,
          height: widget.showDetails ? widget.size + 40 : widget.size,
          margin: EdgeInsets.all(8),
          decoration: _buildDecoration(),
          child: widget.showDetails 
              ? _buildDetailedChip()
              : _buildSimpleChip(),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: widget.isSelected 
          ? widget.crop.color.withOpacity(0.2)
          : (_isHovered ? Colors.grey[50] : Colors.white),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: widget.isSelected 
            ? widget.crop.color
            : Colors.grey.shade300,
        width: widget.isSelected ? 2 : 1,
      ),
      boxShadow: [
        if (widget.isSelected || _isHovered)
          BoxShadow(
            color: widget.crop.color.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildSimpleChip() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Crop Icon
        Container(
          width: widget.size * 0.2,
          height: widget.size * 0.2,
          decoration: BoxDecoration(
            color: widget.crop.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              widget.crop.icon,
              style: TextStyle(fontSize: widget.size * 0.25),
            ),
          ),
        ),
        SizedBox(height: 8),
        
        // Crop Name
        Text(
          widget.crop.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: widget.size * 0.12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        // Selection Indicator
        if (widget.isSelected) ...[
          SizedBox(height: 4),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: widget.crop.color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailedChip() {
    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon and Name
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.crop.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.crop.icon,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.crop.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (widget.isSelected)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: widget.crop.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          
          // Category
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.crop.category,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 8),
          
          // Shelf Life
          Row(
            children: [
              Icon(Icons.timer, size: 12, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text(
                '${widget.crop.shelfLife} days',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          
          // Seasons
          Wrap(
            spacing: 4,
            children: widget.crop.seasons.take(2).map((season) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  season,
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.orange,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}